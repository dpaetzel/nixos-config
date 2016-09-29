''
Section "Monitor"
    Identifier     "HDMI-1"
    Option         "Primary" "true"
    # Option         "DPI"     "96x96"
    # Option         "Position" "1024 200"
    # VendorName     "Samsung"
    # Option         "PreferredMode" "1920x1080"
EndSection

Section "Monitor"
    Identifier     "DVI-I-1"
    Option         "Rotate" "left"
    Option         "LeftOf" "HDMI-1"
    # Option         "DPI"     "96x96"
    # Option         "Position" "0 0"
    # VendorName     "Hyundai"
    # Option         "PreferredMode" "1280x1024"
EndSection

Section "Monitor"
    Identifier     "DVI-D-1"
    Option         "Rotate" "right"
    Option         "RightOf" "HDMI-1"
    Option         "PreferredMode" "1680x1050"
    # Option         "DPI"     "96x96"
    # Option         "Position" "2944 0"
    # VendorName     "Samsung"
EndSection

Section "Screen"
    Identifier     "Main"
    Monitor        "HDMI-1"
EndSection

Section "Screen"
    Identifier     "Left"
    Monitor        "DVI-I-1"
EndSection

Section "Screen"
    Identifier     "Right"
    Monitor        "DVI-D-1"
EndSection
''
