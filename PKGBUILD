pkgname=awmtt
pkgver=0.3
pkgrel=1
pkgdesc="test and preview your awesomewm configuration with xephyr"
arch=('any')
url="https://github.com/mikar/awmtt"
license=('GPL')
depends=('gawk' 'sed' 'xorg-server-xephyr')
source=(https://raw.github.com/mikar/awmtt/master/awmtt)
sha256sums=('f6e4bceed9becb28576474f336934369651c037997b4f18d4faf89dac0865915')

package() {
  install -d ${pkgdir}/usr/bin
  install -m755 ${srcdir}/${pkgname} ${pkgdir}/usr/bin/
}
