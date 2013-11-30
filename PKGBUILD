pkgname=awmtt
pkgver=0.2
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

md5sums=('ee15cec4a31caa3c69808d62ea2f4a82')
