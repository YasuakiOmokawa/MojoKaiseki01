package Kaiseki::DB::connDB;

use utf8;
use Teng;
use Teng::Schema::Loader;
# use Teng::Schema::Dumper;
use DBI;
use Data::Dumper;

sub new{
	my $dbh = DBI->connect(
		# bdi:dbi種類名:database=データベース名;host=ホスト名,
		# 接続ユーザ, パスワード,
		'dbi:mysql:database=kaiseki;host=localhost',
		'kskadmin', 'kskadmin',
		+{
			AutoCommit => 0,
		    PrintError => 1,
		    RaiseError => 1,
		    ShowErrorStatement => 1,
		    AutoInactiveDestroy => 1,
		    mysql_enable_utf8 => 1, # 日本語文字化け対策(mysqlの文字コードに合わせる)
		}
	) or die;

	# print Teng::Schema::Dumper->dump(
	# 	dbh => $dbh,
	# 	namespace => 'Kaiseki::DB',
	# 	);

	my $teng = Teng::Schema::Loader->load(
		dbh => $dbh,
		namespace => 'Kaiseki::DB'
	);
	return $teng;
}

1;