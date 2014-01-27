package Kaiseki::Web;

use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  # $self->plugin('PODRenderer');
  
  # Router
  my $r = $self->routes;

  # Controller search path
  $r->namespaces(['Kaiseki::Web::Controller']);
  
  # Normal route to controller
  $r->get('/')->to(controller => 'root', action => 'index');
  # $r->get('/selectdetail')->to(controller => 'root', action => 'selectdetail');
  $r->post('/selectdetail')->to(controller => 'root', action => 'selectdetail');
  $r->get('/detail')->to(controller => 'root', action => 'detail');
  # $r->get('/result')->to(controller => 'root', action => 'result');
  # $r->get('/addKekka')->to(controller => 'root', action => 'addKekka');
}

1;
