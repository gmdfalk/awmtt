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

md5sums=('e2651ff4e1be85baa01d59a7e2598cb5')
