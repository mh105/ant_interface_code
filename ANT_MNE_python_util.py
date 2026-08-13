"""
Functions for interfacing three platforms:
- ANT eego mylab records (.cnt)
- MATLAB EEGLAB data structure (.set)
- MNE data structure (_raw.fif)

1)
We use MATLAB ANT_interface codes to import raw .cnt data from ANT eego
mylab EEG system into an EEGLAB .set file. Then we use the utility
functions in this .py file to create MNE _raw.fif file of the recording.
Subsequent processing can take place in python directly on the _raw.fif
file.

2)
In the process of creating the _raw.fif file, we need a digitization of
the electrodes. Utility functions here will take outputs of MATLAB
ANT_MNE_fastscan.m and create the required Montage object for creating
a _raw.fif file


    # UPDATE: MNE v0.19+ uses a different set of API, this library has been adjusted to accommodate
    the newest version of MNE for the new API. It should be back-compatible for versions before
    v0.19 such as v0.18.2, but I haven't tested this library for back-compatibility.

https://mne.tools/stable/auto_tutorials/intro/plot_40_sensor_locations.html#sphx-glr-auto-tutorials-intro-plot-40-sensor-locations-py

------------------------
Last update:
Alex He - 08/13/2026
"""


def ant_mne_dig2mont(montage, digmontage, kind='duke129_dig'):
    """
    This function is used to convert the information from a
    DigMontage object to a Montage object. It handles some
    peculiarities of how the channels are ordered. This is
    necessary because mne.io.read_raw_eeglab only accepts
    Montage but not DigMontage as input.

    # UPDATE: MNE v0.19+ uses a different set of APIs, this function is only called by MNE versions prior to v0.19

    :param montage: a MNE Montage object created from loading
                    a template montage (e.g. biosemi128)

    :param digmontage: a MNE DigMontage object constructed from
                       electrode and landmark coordinates read
                       from .csv file created by a MATLAB
                       function ANT_MNE_fastscan.m using MNE
                       function read_dig_montage

    :param kind: a string specifying the new Montage object
                 created. We expect it to be duke129_dig, which
                 is an arbitrary name that I give the Montage

    :return:
             montage: a MNE Montage object with digitization
                      of electrode and landmark coordinates
    """
    import numpy as np

    # provide a kind label for the new montage
    montage.kind = kind

    # append the anatomical landmarks to the channel channel
    montage.ch_names = digmontage.point_names + ['Nz', 'LPA', 'RPA']

    # update the landmark positions
    montage.nasion = digmontage.nasion
    montage.lpa = digmontage.lpa
    montage.rpa = digmontage.rpa

    # update electrode and landmark positions .shape = (132, 3)
    newpos = np.row_stack((digmontage.elp, digmontage.nasion, digmontage.lpa, digmontage.rpa))
    montage.pos = newpos

    # update the selection vector (adding 1 due to the 1 additional EOG channel on duke_129)
    montage.selection = np.append(montage.selection, 131)

    # confirm number of channels not changed
    assert montage.pos.shape == (132, 3), 'Dimension of montage positions is changed!'
    assert np.all(montage.selection == np.arange(132)), 'Selection index is not selecting all 132 positions!'

    return montage


def ant_mne_create_montage(csvfn, dig_filepath, new_MNEv=True):
    """
    This function is used to create a Montage object from
    FastScanII acquired landmark and electrode locations. It
    expects a .csv file created using a MATLAB function
    ANT_MNE_fastscan.m that has a manual quality control of
    the labeling in EEGLAB 2D topoplot against Duke template.
    - expects a .csv file with anatomical landmark (fiducial)
    and electrode labels and coordinates.

    # UPDATE: MNE v0.19+ uses a different set of APIs, this function modified to accommodate the new API

    :param csvfn: file name of the .csv file

    :param dig_filepath: full path to the folder containing
                         the .csv file

    :param new_MNEv: whether to use routine for newer MNE version

    :return:
             montage: a MNE Montage object with digitization
                      of electrode and landmark coordinates
                      if MNE v0.19+ is sued, montage is a DigMontage object
    """
    import os.path as op
    import numpy as np
    from pandas import read_csv

    # print message
    print('Creating digitized montage using .csv file: ' + csvfn)

    # configure full path name of the .csv file
    fname = op.join(dig_filepath, csvfn)

    # load in the .csv file with labels and XYZ values
    df = read_csv(fname)

    # create a list of labels
    point_names = [x.strip() for x in df.labels.to_numpy()]

    # create a numpy.ndarray of xyz values of electrode position points
    xyz = df[['X', 'Y', 'Z']]
    elp = xyz.to_numpy()

    # do different things depending on the MNE version
    if new_MNEv:
        from mne.channels import make_dig_montage

        ch_xyz_in_m = elp[3:, :] / 1000  # make_dig_montage expects coordinates to be in unit of meters
        ch_label = point_names[3:]
        assert len(ch_label) == ch_xyz_in_m.shape[0] == 129 and ch_xyz_in_m.shape[1] == 3, \
            'Dimensions of labels and electrodes are incorrect!'

        ch_pos = dict()
        for x in range(len(ch_label)):
            ch_pos[ch_label[x]] = ch_xyz_in_m[x, :]
        nasion = elp[point_names.index('nasion'), :] / 1000
        lpa = elp[point_names.index('lpa'), :] / 1000
        rpa = elp[point_names.index('rpa'), :] / 1000

        montage = make_dig_montage(ch_pos=ch_pos, nasion=nasion, lpa=lpa, rpa=rpa)

    else:
        from mne.channels import read_montage
        from mne.channels import read_dig_montage

        # compute the distance between right and left preauricular points in imported data
        old_ppd = np.linalg.norm(elp[point_names.index('rpa')] - elp[point_names.index('lpa')])

        # check that dimensions of labels and electrode coordinates are consistent
        # here we expect using ANT Duke Waveguard cap with 129 electrodes
        assert len(point_names) == elp.shape[0] == 132 and elp.shape[1] == 3, \
            'Dimensions of labels and electrodes are incorrect!'

        # create a DigMontage object
        #   - since we are specifying fidicuals (nasion, lpa, and rpa), setting transform=True will
        #   automatically convert the elp positions in digmontage to MNE head coordinates system.
        #   The unit will also be transformed from 'mm' to 'm' in calling read_dig_montage
        digmontage = read_dig_montage(elp=elp, point_names=point_names, unit='auto', transform=True)

        # compute the new distance after transforming in MNE head coordinates system and rescaled to meter
        new_ppd = np.linalg.norm(digmontage.rpa - digmontage.lpa) * 1000  # rescale to mm as in FastScanII

        # check that the preauricular point distance is not altered and in correct scale
        assert abs(new_ppd - old_ppd) < 1e-12, \
            'Preauricular point distance is changed in creating montage!'

        # create an instance of a fake Montage object
        montage = read_montage(kind='biosemi128')

        # convert the information from DigMontage object to Montage object
        montage = ant_mne_dig2mont(montage, digmontage, kind='duke129_dig')

    return montage


def ant_mne_create_raw(setfn, set_filepath, csvfn, dig_filepath, overwrite=True):
    """
    This function is used to create a MNE Raw object by
    loading an EEGLAB .set file. The created Raw object
    will also be saved with suffix _raw.fif appended,
    in the same directory as that of the .set file.

    # UPDATE: MNE v0.19+ uses a different set of API, this function has been adjusted to accommodate
    the newest version of MNE for the new API. It should be back-compatible for versions before
    v0.19 such as v0.18.2, but I haven't tested this function for back-compatibility.

    :param setfn: file name of the .set file

    :param set_filepath: full path to the folder containing
                         the .set file. This same path will
                         also be used for saving the
                         constructed _raw.fif file

    :param csvfn: file name of the .csv file with
                  corresponding digitization of electrode
                  and landmark coordinates to the .set file
                  recording session. The .csv file is
                  outputted from a MATLAB function
                  ANT_MNE_fastscan.m

    :param dig_filepath: full path to the folder containing
                         the .csv file

    :param overwrite: whether to overwrite existing _raw.fif
                      file

    :return:
             raw: a MNE Raw object with all data in the .cnt
                  recording as well as the digitization of
                  electrode and landmark coordinates acquired
                  by Polhemus FastScanII scanner, along
                  with other info standard to a MNE Raw
                  object. All subsequent processing in
                  python can start with this data structure
    """
    import os.path as op
    import mne
    from mne.io import read_raw_eeglab
    import matplotlib.pyplot as plt

    # Get MNE version number
    mne_version = mne.__version__
    mne_version_n = [int(x) for x in mne_version.split('.')]

    # configure file name of the .set file
    fname = op.join(set_filepath, setfn)

    if mne_version_n[0] < 0 and mne_version_n[1] < 19:

        # construct a montage object
        montage = ant_mne_create_montage(csvfn, dig_filepath, new_MNEv=False)

        # create a mne.io.Raw object of the data with montage input
        print('Loading .set file: ' + setfn)
        raw = read_raw_eeglab(input_fname=fname, montage=montage, preload=True)

        # save this raw object in a FIF format to set_filepath directory
        if overwrite is not None:
            fif_fname = op.join(set_filepath, setfn.strip('.set') + '_raw.fif')
            raw.save(fif_fname, fmt='single', overwrite=overwrite)

    else:

        # create a mne.io.Raw object of the data
        print('Loading .set file: ' + setfn)
        raw = read_raw_eeglab(input_fname=fname, preload=True)

        fig = plt.figure()
        ax1 = fig.add_subplot(121)
        ax2 = fig.add_subplot(122)

        # visualize the default template electrode montage (Duke Waveguard 128+EOG)
        raw.plot_sensors(show_names=True, axes=ax1)

        # construct a DigMontage object
        montage = ant_mne_create_montage(csvfn, dig_filepath, new_MNEv=True)

        # update the Raw object with digitization montage information
        raw = raw.set_montage(montage)

        # visualize the default template electrode montage (Duke Waveguard 128+EOG)
        raw.plot_sensors(show_names=True, title='Duke Template (LEFT) vs. Subject Specific Montage (RIGHT)', axes=ax2)

        # save this raw object in a FIF format to set_filepath directory
        if overwrite is not None:
            fif_fname = op.join(set_filepath, setfn.strip('.set') + '_raw.fif')
            raw.save(fif_fname, fmt='single', overwrite=overwrite)

    return raw
