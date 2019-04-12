## Redshift grant horker
Another one of those things that is childishly simple in MySQL that is a train wreck in Redshift/Postgres.

## What it does
Spits out executable SQL based on precisely the permissions each user has in the Redshift instance.  It's not pretty,
and it doesn't save group membership, but it does show who gets access to what.