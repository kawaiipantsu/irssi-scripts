##
# CohhCarnage - Twitch TV
# - Simple Giveaway detecter and automatic !enter script
##


## Giveaway pattern 28 Feb 2018
# 28.1640'30  cohhilition *** A NEW GIVEAWAY IS OPEN: (The Inner World): Sponsored by Ejento! (10 Tokens - Regular Giveaway) This is a promotion from CohhCarnage. Twitch does not sponsor or endorse broadcaster promotions and is not responsible for them. ***
# 28.1640'30  cohhilition *** Type !enter to be entered to win. [ID:147] ***
# ......
# 28.1643'30  cohhilition *** The winner is: thesh4d0w *** You have won The Inner World donated by Ejento. You will be contacted via Twitch PM by a moderator. This was a promotion from CohhCarnage. Twitch does not sponsor or endorse broadcaster promotions and is not responsible for them.
####################################

use strict;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;

$VERSION = '0.00.04';
%IRSSI = (
	authors			=> 'KawaiiPantsu',
	contact			=> '@davidbl',
	name			=> 'cohh-giveaway',
	description		=> 'An easy way to auto enter any giveaway that Twitch TV user Cohhcarnage runs.',
	license			=> 'GNU GPL Version 2 or later',
	url			=> 'https://github.com/kawaiipantsu/irssi-scripts'	
);

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

	if ( $nick != "cohhilition") {	return 0; }

	# Handle Give Away (START)
	if ( $msg =~ /^\*\*\* A NEW GIVEAWAY IS OPEN: \((.*)\):.*/i) {
		my $windowname = Irssi::window_find_name('HL');
		my $gamename = $1;
		$windowname->print("%W%0GIVEAWAY : ".$target." -> Giveaway started for game: $gamename",MSGLEVEL_CLIENTCRAP) if ($windowname);
		giveawayLog($nick,$target,$msg);
		# Sending !enter command and also waiting for 2 - 4 sec randomly before posting the command!
                sleep (int(rand(2)) + 2);
		$server->command("msg ".$target." !enter");
		return 0;
	}
	# Handle Give Away (END)
	if ( $msg =~ /^\*\*\* The winner is: (.*) \*\*\*.*/i) {
		my $windowname = Irssi::window_find_name('HL');
		my $winner = $1;
		$windowname->print("%W%0GIVEAWAY : ".$target." -> Giveaway ended winner is $winner",MSGLEVEL_CLIENTCRAP) if ($windowname);
		giveawayLog($nick,$target,$msg);
		# I am the winner !!
		if ( $winner == "readyupdave" ) {
                	sleep (int(rand(2)) + 2);
			$server->command("msg ".$target." Yay! :D");
		}

		return 0;
	}

	#my $windowname = Irssi::window_find_name('HL');
	#$windowname->print("%W%0ACTION : ".$nick." -> ".$target." saying ".$msg,MSGLEVEL_CLIENTCRAP) if ($windowname);

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
