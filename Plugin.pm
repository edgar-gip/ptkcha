# Interficie Plugin
# L'han d'heretar tots els plugins

package Plugin;

# Constructor
# Rep com a parametre una instancia de la interficie principal
sub new { die "Abstract Operation\n" }

# Destructor
sub free { die "Abstract Operation\n" }

# Crear Menu
# Rep com a parametre el pare
sub makeMenu { die "Abstract Operation\n" }

# Retornem cert
1;

