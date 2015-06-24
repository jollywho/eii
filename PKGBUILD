pkgname=eii
pkgver=1.0.0
pkgrel=1
pkgdesc="interactive sqlite in bash"
arch=('any')
url="https://github.com/jollywho/eii"
license=('GPL')
depends=('bash' 'sqlite3')
source=("git://github.com/jollywho/$pkgname.git")

package() {
  cd "$pkgname"
  make DESTDIR="${pkgdir}" install
}
md5sums=('SKIP')
