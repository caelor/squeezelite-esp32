package Plugins::SqueezeESP32::Plugin;

use strict;

use base qw(Slim::Plugin::Base);

use Digest::MD5 qw(md5);
use List::Util qw(min);
use Slim::Utils::Prefs;
use Slim::Utils::Log;
use Slim::Web::ImageProxy;

my $prefs = preferences('plugin.squeezeesp32');

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.squeezeesp32',
	'defaultLevel' => 'INFO',
	'description'  => Slim::Utils::Strings::string('SqueezeESP32'),
}); 

sub initPlugin {
	my $class = shift;
	
	if ( main::WEBUI ) {
		require Plugins::SqueezeESP32::PlayerSettings;
		Plugins::SqueezeESP32::PlayerSettings->new;
		
		# require Plugins::SqueezeESP32::Settings;
		# Plugins::SqueezeESP32::Settings->new;
	}
	
	$class->SUPER::initPlugin(@_);
	Slim::Networking::Slimproto::addPlayerClass($class, 100, 'squeezeesp32', { client => 'Plugins::SqueezeESP32::Player', display => 'Plugins::SqueezeESP32::Graphics' });
	$log->info("Added class 100 for SqueezeESP32");
	
	Slim::Control::Request::subscribe(\&onNotification, [ ['newmetadata'] ] );
	Slim::Control::Request::subscribe(\&onNotification, [ ['playlist'], ['open', 'newsong'] ]);
}

sub onNotification {
    my $request = shift;
    my $client  = $request->client;
	
	my $reqstr     = $request->getRequestString();
	$log->info("artwork update notification $reqstr");
	#my $path = $request->getParam('_path');

	update_artwork($client);
}

sub update_artwork {
    my $client  = shift;
	my $force = shift || 0;
	my $cprefs = $prefs->client($client);
	my $artwork = $cprefs->get('artwork');
		
	return unless $client->model eq 'squeezeesp32' && $artwork->{'enable'};

	my $s = $artwork->{'y'} >= 32 ? $cprefs->get('height') - $artwork->{'y'} : 32;
	$s = min($s, $cprefs->get('width') - $artwork->{'x'});
	
	my $path = 'music/current/cover_' . $s . 'x' . $s . '_o.jpg';
	my $body = Slim::Web::Graphics::artworkRequest($client, $path, $force, \&send_artwork, undef, HTTP::Response->new);
	
	send_artwork($client, undef, \$body) if $body;
}

sub send_artwork {
	my ($client, $force, $dataref) = @_;
	
	# I'm not sure why we are called so often, so only send when needed
	my $md5 = md5($$dataref);
	return if $client->pluginData('artwork_md5') eq $md5 && !$force;
	
	$client->pluginData('artwork', $dataref);
	$client->pluginData('artwork_md5', $md5);
	
	my $artwork = $prefs->client($client)->get('artwork');
	my $length = length $$dataref;
	my $offset = 0;
	
	$log->info("got resized artwork (length: ", length $$dataref, ")");
	
	my $header = pack('Nnn', $length, $artwork->{'x'}, $artwork->{'y'});
	
	while ($length > 0) {
		$length = 1280 if $length > 1280;
		$log->info("sending grfa $length");
			
		my $data = $header . pack('N', $offset) . substr( $$dataref, 0, $length, '' );
			
		$client->sendFrame( grfa => \$data );
		$offset += $length;			
		$length = length $$dataref;
	}
}	

1;
