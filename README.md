# Radiology-Review-Workspace-FLAIR-A-G
fast visual review and workspace setup for multiple scans (titled "a-g") at one chosen timepoint at a time in FIJI/ImageJ as nifti files. 
# FLAIR Timepoint Review Macro

ImageJ/Fiji macro for opening and arranging selected FLAIR/T2 review datasets from a subject folder.

This macro is designed for fast visual review of one chosen timepoint at a time. It lets you choose a parent folder, select a timepoint, choose which series labels to load (A-G), optionally load a Results_Timepoint folder, apply contrast enhancement, jump each stack to its middle slice, zoom to the image center, and place the windows in a consistent screen layout.

## What it does

- Prompts for a parent subject folder.
- Lets you choose a single timepoint from a dropdown, for example 1, 2, 3, or 4.
- Lets you choose which series to open using checkboxes for A, B, C, D, E, F, and G.
- Lets you optionally open one Results_Timepoint folder.
- Opens matching folders for the selected timepoint, such as 1a / 1b / 1e / 1f or 3a / 3b / 3e / 3f.
- Opens each selected folder as a sequence.
- Moves each stack to the middle slice.
- Runs Enhance Contrast using the chosen saturation value.
- Sets zoom with the recorded `Set...` command using the center of the image.
- Arranges windows differently depending on whether you selected single-screen laptop or three-monitor layout.

## Expected folder structure

The macro expects a parent folder that contains subfolders for one or more timepoints. Examples:

- `1a_...`
- `1b_...`
- `1e_...`
- `1f_...`
- `2a_...`
- `2b_...`
- `3a_...`
- `4f_...`
- `Results_Timepoint1`
- `Results_Timepoint2`
- `Results_Timepoint3`

The folder matcher is based on the selected timepoint plus the series letter, so choosing timepoint `3` and series `A` makes the macro look for a folder name containing or starting with `3a`.

## Dialog options

The main dialog includes:

- Timepoint dropdown.
- A-G checkboxes.
- Results folder dropdown.
- Display layout dropdown.
- Contrast saturation numeric field.

### Display layout choices

- `Single-screen laptop`
- `Three monitors`

The three-monitor layout uses a custom anchor position so that window A starts at the preferred monitor-3 location.

## Typical workflow

1. Run the macro in Fiji.
2. Choose the parent subject folder.
3. Choose the timepoint you want to review.
4. Check the series you want to open.
5. Choose the Results_Timepoint folder if needed.
6. Choose the display layout.
7. Enter or accept the contrast saturation value.
8. The macro opens the selected image folders, moves to the middle slice, enhances contrast, sets zoom, and arranges the windows.

## Important implementation notes

- The macro currently uses `File.openSequence()` for each selected folder.
- The zoom step uses the recorder-derived command:
  `run("Set... ", "zoom=... x=... y=...");`
- Window placement uses `setLocation(x, y)`, which means layouts are based on desktop screen coordinates, not monitor numbers directly.
- The three-monitor mode is implemented using the preferred coordinates measured from the active display setup.

## Known limitations

- Window placement depends on your current monitor arrangement and resolution.
- If monitor layout changes, the saved coordinates may need adjustment.
- Folder-name matching is only as good as the naming consistency of the source folders.
- If a selected series is not found, the macro prints a “Missing folder for ...” message in the log.
- If folders contain a single NIfTI file rather than a stack of sequence-readable images, the open logic may eventually need to switch from `File.openSequence()` to opening the exact file path.

## Debugging helpers currently used

Some debug logging may still be present, such as:
- printing parent folder contents
- printing each folder name checked during matching

These are useful while validating folder matching and can be removed later once the macro is stable.

## Future improvements
Possible future additions:

- synchronized scrolling for A/B and E/F pairs
- exact NIfTI-file detection instead of folder sequence opening
- ROI Manager integration
- saved monitor presets for different desk setups
- cleaner handling of multiple Results timepoints
