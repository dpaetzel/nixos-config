''
Section "Monitor"
    Identifier     "HDMI-0"
    # Option         "Position" "1024 200"
    # VendorName     "Samsung"
    # Option         "PreferredMode" "1920x1080"
EndSection

Section "Monitor"
    Identifier     "DVI-I-0"
    Option         "Rotate" "left"
    # Option         "Position" "0 0"
    # VendorName     "Hyundai"
    # Option         "PreferredMode" "1280x1024"
EndSection

Section "Monitor"
    Identifier     "DVI-D-0"
    Option         "Rotate" "right"
    # Option         "Position" "2944 0"
    # VendorName     "Samsung"
    # Option         "PreferredMode" "1680x1050"
EndSection

Section "Screen"
    Identifier     "Main"
    Monitor        "HDMI-0"
    Option         "Primary" "true"
    Option         "DPI"     "96x96"
    # Option         "Position" "1024 200"
EndSection

Section "Screen"
    Identifier     "Left"
    Monitor        "DVI-I-0"
    Option         "LeftOf" "Main"
    Option         "DPI"     "96x96"
    # Option         "Position" "0 0"
EndSection

Section "Screen"
    Identifier     "Right"
    Monitor        "DVI-D-0"
    Option         "RightOf" "Main"
    Option         "DPI"     "96x96"
    # Option         "Position" "2944 0"
EndSection
''
