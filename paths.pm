package Env::paths;

use strict;
use Env::path;

sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;

  $self->{'prefix'} = shift || '';

  return $self;
}

sub static {
  my $self = shift;
  my $variable = shift;
  
  my $temp = new Env::path($variable, @_);
  $temp->{'utok'} = 0;

  push @{$self->{'variables'}}, $temp;


  return $self;
}


# prefix the first argument with what ever is in $self->{'prefix'}.
sub prefix {
  my $self = shift;
  my $path = shift;

  if ($path =~ m/^[\/\$]/) {
    return $path;
  } else {
    return "$self->{prefix}/$path";
  }
}

sub add {
  my $self = shift;
  my $variable = shift;

  push @{$self->{'variables'}}, new Env::path($variable, map($self->prefix($_), @_));

  return $self;
}

sub save {
  my $self = shift;
  my $file = shift;

  if (!defined $file) {
    $file = $self->{'prefix'};
  } else {
    $file = $self->prefix($file);
  }

  if (open(CSH, ">${file}.csh")) {
    print CSH $self->csh();
    close(CSH);
  }

  if (open(SH, ">${file}.sh")) {
    print SH $self->sh();
    close(SH);
  }

  return $self;
}

sub csh {
  my $self = shift;

  my $output = '';
  for (@{$self->{'variables'}}) {
    $output .= $_->csh();
  }

  return $output;
}


sub sh {
  my $self = shift;

  my $output = '';
  for (@{$self->{'variables'}}) {
    $output .= $_->sh();
  }

  if (!$Env::path::sh_export) {
    $output .= 'export ';
    for (@{$self->{'variables'}}) {
      $output .= "$_->{variable} ";
    }
    $output =~ s/ $/\n/;
  }

  return $output;
}

return 1;

