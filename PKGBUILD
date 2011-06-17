pkgname=awmtt
pkgver=0.1
pkgrel=1
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

md5sums=('08dc87f0177feb38f1b0ee19a3970534')
