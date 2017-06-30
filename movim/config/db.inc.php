<?php

$conf = [
    'type'        => 'pgsql',
    'username'    => $_ENV['POSTGRES_USER'],
    'password'    => $_ENV['POSTGRES_PASSWORD'],
    'host'        => 'postgres',
    'port'        => 5432,
    'database'    => $_ENV['POSTGRES_DB']
];
