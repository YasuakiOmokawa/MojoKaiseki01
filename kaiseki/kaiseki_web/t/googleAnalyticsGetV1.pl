#!/usr/bin/env perl

## Google Analytics API をPerlから使うためのスクリプト。
## リフレッシュトークンの取得を実施する。

use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;

# Google Analytics アクセス用

use Net::Google::Analytics::OAuth2;


my $oauth = Net::Google::Analytics::OAuth2->new(

	client_id => $ARGV[0],
	client_secret => $ARGV[1],
	redirect_uri => 'https://localhost/oauth2callback',
);

$oauth->interactive;

# my $url = $oauth->authorize_url;
# $url = $url . '&approval_prompt=force&access_type=offline'; 
# print $url,"\n";
			#my $code = '4/wBKdl-NQ5Hp5OzVCgKNsBulaple0.wg1PFzG96CcWgrKXntQAax1wW7_kiQI';
			#my $token = $oauth->get_access_token($code);
			#print Dumper $token,"\n";

# my $mech = new WWW::Mechanize( autocheck => 1 );



# # トップにアクセスし、

#  $mech->get($url);
# print $mech->uri(),"\n";
# print $mech->title(),"\n";


#  $mech->click_button(number => 1);



#  print $mech->title(),"\n";





