pkgname=awmtt
pkgver=0.1
pkgrel=2
pkgdesc="tests your awesomewm configuration with xephyr"
arch=('any')
url="https://github.com/mikar/awmtt"
license=('GPL')
depends=('gawk' 'sed' 'xorg-server-xephyr')
source=(https://raw.github.com/mikar/awmtt/master/awmtt)

build() {
  install -d	${pkgdir}/usr/bin
  install -m755 ${srcdir}/${pkgname} ${pkgdir}/usr/bin/
}

md5sums=('1c2246892332e13f441bd6ce2c156a01')
