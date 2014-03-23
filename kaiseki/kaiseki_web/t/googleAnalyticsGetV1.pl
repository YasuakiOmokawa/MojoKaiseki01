#!/usr/bin/env perl

use strict;
use warnings;

# Google Analytics アクセス用
use Net::Google::Analytics::OAuth2;

# 
my $oauth = Net::Google::Analytics::OAuth2->new(
	client_id => '56569116934-sjp0djn8uc0pjk98401v8mpqo0d0oivp.apps.googleusercontent.com',
	client_secret => 'D2OpvsK7SBtKDHdrq4DDYh8O',
	redirect_uri => 'https://localhost/oauth2callback',
);

$oauth->interactive;

