D3BEAM : dialog {
  label = "DRAW 3D BEAM";

  : boxed_row {
    label = "Choose Type of Beam to Draw:";
      : popup_list {
        edit_width = 20;
        key = "beam";
        value = 0;
        label = "Beam Type:";
        list = "W4x13\nW5x16\nW5x18.5\nW6x8.5\nW6x12";
        }
    }
  : boxed_row {
    label = "Elevations:";
      : radio_column {
        : radio_button {
          label = "Enter Different Elevations at each End (Sloped Beams).";
          key = "sloped";
          }
        : radio_button {
          label = "Use Elevation (Flat Beams):";
          value = "1";
          key = "flat";
          }
        : boxed_column {
          label = "Flat Beam Elevation";
          key = "reference";
        : edit_box {
          label = "Enter Elevation:";
          key = "elev";
          }
        : radio_row {
          : radio_button {
            label = "B.O.S.";
            value = "1";
            key = "BOS";
            }
          : radio_button {
            label = "T.O.S.";
            key = "TOS";
            }
          }
          }
        }
      }
  : row {
    : spacer { width = 1; }
    : button {
      label = "OK";
      is_default = true;
      key = "accept";
      width = 8;
      fixed_width = true;
      }
    : button {
      label = "Cancel";
      is_cancel = true;
      key = "cancel";
      width = 8;
      fixed_width = true;
      }
    : spacer { width = 1;}
  }

}