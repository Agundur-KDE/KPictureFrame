%ifarch aarch64
%undefine source_date_epoch_from_changelog
%endif

Name:           kpictureframe
Version:        2.1.0
Release:        1%{?dist}
Summary:        KDE Plasma 6 picture frame for your desktop

License:        GPL-3.0-or-later
URL:            https://github.com/Agundur-KDE/KPictureFrame


BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  gettext
BuildRequires:  qt6-base-devel
BuildRequires:  qt6-declarative-devel
BuildRequires:  kf6-extra-cmake-modules
BuildRequires:  kf6-ki18n-devel


Requires:       plasma6-workspace

%description
KPictureFrame is a KDE Plasma 6 widget that displays a user-defined image
(PNG, JPG, SVG) on the desktop — for personal photos, logos, or QR codes,
with drag & drop support. Supports a folder slideshow mode and an ambient
glow effect, and is translated into German, Spanish and French.

Source0: _service

%prep

rm -rf ./*

shopt -s nullglob
picked=""
for d in %{_sourcedir}/KPictureFrame-* %{_sourcedir}/kpictureframe-* %{_sourcedir}/KPictureFrame ; do
  if [ -d "$d" ] && [ -f "$d/CMakeLists.txt" ]; then
    picked="$d"
    break
  fi
done

if [ -n "$picked" ]; then
  cp -a "$picked"/. .
else
  for f in %{_sourcedir}/* ; do
    base="$(basename "$f")"
    case "$base" in
      *.spec|*.dsc|*.changes|*.obsinfo|_service|service_attic|screenshot|*.patch)
        continue ;;
    esac
    cp -a "$f" .
  done
fi

%build
%cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX=%{_prefix}
%cmake_build

%install
%cmake_install


%files
%license LICENSE
%doc README.md
%dir %{_datadir}/plasma/plasmoids/de.agundur.kpictureframe
%dir %{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents
%dir %{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/ui
%dir %{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/config
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/metadata.json
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/ui/main.qml
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/ui/FullRepresentation.qml
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/ui/configPictures.qml
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/ui/cat.webp
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/config/main.xml
%{_datadir}/plasma/plasmoids/de.agundur.kpictureframe/contents/config/config.qml
%{_datadir}/locale/*/LC_MESSAGES/plasma_applet_de.agundur.kpictureframe.mo

%changelog
* Sun Jul 12 2026 Alec <info@agundur.de> - 2.1.0
- Added folder slideshow mode (drag & drop a folder or pick one in settings)
- Added ambient glow effect (blurred halo behind the picture, toggleable)
- Added explicit Single picture / Slideshow mode selector in settings
- Added KI18N translation pipeline with German, Spanish and French translations

* Wed Jul 08 2026 Alec <info@agundur.de> - 2.0.0
- Switched OBS source service from tar_scm/HEAD to obs_scm pinned to release tags
- Fixed wrong Summary/description (was copy-pasted from EZMonitor)
- CMakeLists.txt no longer needs a C++ toolchain (pure QML, dead includes removed)
