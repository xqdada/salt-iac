base-install:
  pkg.installed:
    - pkgs:
      - sysstat
      - ntpdate
      - libaio
      - libaio-devel
      - libpng
      - libpng-devel
      - curl
      - curl-devel
      - glibc.i686

install_pkgs_with_wildcard:    
  cmd.run:
    - name: |
        packages=("libxml2*" "libstdc++*" "libstdc++*.i686")
        for pkg in "${packages[@]}";do
            yum install -y $pkg||echo "$pkg already installed or Failed to install $pkg, but continuing..."
        done 
    - unless: rpm -qa | grep -qE '^(libstdc++.*i686$)'

