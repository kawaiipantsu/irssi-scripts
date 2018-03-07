##
# CohhCarnage - Twitch TV
# - Simple Giveaway detecter and automatic !enter script
##
#
# This script is just ment for fun and it's a easy way to enter Cohhcarnage's
# Giveaways if you are using Irssi as a chat client for Twitch TV. Please note
# this is not fully auto, you will still need to reply to their giveaway if you win.
#
# Please note that you need the Highlite plugin as well and your Highlite window
# must be named "HL". I know the default is called something else but this is how
# i made it. But search for 'HL' and changed it where needed if your highlite window
# is called something else. Cheers! 
#
###############

use strict;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;

$VERSION = '0.01.00';
%IRSSI = (
	authors			=> 'David BL',
	contact			=> 'dbl@darknet.dk',
	name			=> 'cohh-giveaway',
	description		=> 'An easy way to auto enter any giveaway that Twitch TV user Cohhcarnage runs.',
	license			=> 'GNU GPL Version 2 or later',
	url			=> 'https://github.com/kawaiipantsu/irssi-scripts'	
);


### Your Twtich TV IRC Nickname
##
## Dont forget that it's always is lower case!

my $twitchtv_nick = "mytwitchnick";

######################################################################


##
# Pre checks
##
my $file = "$ENV{HOME}/.irssi/cohh-giveaways.log";
my $windowname = Irssi::window_find_name('HL');
if (!$windowname) {
	# Do we want to do anything if the HL window is not there ?
}

##
# Prepare signals
##
sub public_giveaway {
	my ($server, $msg, $nick, $address, $target) = @_;
	signalHandler($server, $msg, $nick, $target, $address);
}

sub private_giveaway {
	my ($server, $msg, $nick, $address, $target) = @_;
	signalHandler($server, $msg, $nick, $target, $address);
}

sub action_giveaway {
	my ($server, $msg, $nick, $address, $target) = @_;
	signalHandler($server, $msg, $nick, $target, $address);
}

##
# Main signalHandler
##
sub signalHandler($server, $msg, $nick, $target, $address) {
	my ($server, $msg, $nick, $target, $address) = @_;

	# No need to do to much work if it's not even the GiveAway bot!
	if ( $nick != "cohhilition") {	return 0; }

	# Handle Give Away (START)
	if ( $msg =~ /^\*\*\* A NEW GIVEAWAY IS OPEN: \((.*)\):.*/i) {
		my $windowname = Irssi::window_find_name('HL');
		my $gamename = $1;
		$windowname->print("%W%0GIVEAWAY : ".$target." -> Giveaway started for game: $gamename",MSGLEVEL_CLIENTCRAP) if ($windowname);
		giveawayLog($nick,$target,$msg);
		# Sending !enter command after 3 seconds
		Irssi::timeout_add_once(3000, sub { 
			$server->command("msg ".$target." !enter");
		}, undef);
		return 0;
	}
	# Handle Give Away (END)
	if ( $msg =~ /^\*\*\* The winner is: (.*) \*\*\*.*/i) {
		my $windowname = Irssi::window_find_name('HL');
		my $winner = $1;
		$windowname->print("%W%0GIVEAWAY : ".$target." -> Giveaway ended winner is: $winner",MSGLEVEL_CLIENTCRAP) if ($windowname);
		giveawayLog($nick,$target,$msg);
		# I am the winner !!
		if ( $winner eq $twitchtv_nick ) {
			Irssi::timeout_add_once(3000, sub { 
				$server->command("msg ".$target." Yaaay! :D");
			}, undef);
			giveawayLog($nick,$target,"I WON! - Check Twitch notifications and or private message.");
		}
		return 0;
	}
	return 0;
}

sub giveawayLog {
	my($nick,$channel,$msg) = @_;

   	open(GIVEAWAYLOG, ">>", $file) or return;
   	print GIVEAWAYLOG time." $nick @ $channel -> $msg\n";
  	close(GIVEAWAYLOG);
}



##
# Set active signals
##

signal_add("message irc action", "action_giveaway");	# Look at action messages in channels

#signal_add("message public", "public_giveaway");   	# Look at public messages in channels

#signal_add("message private", "private_giveaway"); 	# Look at private messages from users
