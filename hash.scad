//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    hash.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Implementation of a hash associative array.
//

// hash can be initialized like:
//
//   config = hash_add( hash_add( hash_add( hash_initialize(), "first_name", "Bob" ), "last_name", "Doe" ), "age", 50 );
//
// or perhaps more clearly like:
//
//   config = [
//     [ "first_name", "Bob" ],
//     [ "last_name", "Doe" ],
//     [ "age", 50 ],
//   ];
//
// Then values can be retrieved by:
//
//   echo( hash_get( config, "first_name" ) ) -> "Bob"
//
// Default values can be obtained as follows if the key is missing from the hash:
//
//   echo( hash_get_default( config, "age", 0 ) ) -> 50
//   echo( hash_get_default( config, "occupation", "unknown" ) ) -> "unknown"
//
// Or, you can have an entire hash of default values to fallback on:
//
//   default_config = [
//     [ "first_name", "none" ],
//     [ "last_name", "none" ],
//     [ "age", 0 ],
//     [ "occupation", "unemployed" ],
//   ];
//
//   echo( hash_get_default_hash( config, "age", default_config ) ) -> 50
//   echo( hash_get_default_hash( config, "occupation", default_config ) ) -> "unemployed"
//
// Functions like 'hash_set' and 'hash_delete' require you to assign the result
// to a new variable, since openscad does not have true variables.
//
//   anon_config = hash_delete( hash_delete( config, "first_name" ), "last_name" );
//   echo( hash_exists( anon_config, "first_name" ) ) -> false
//

// hash_initialize:
//
// Returns initialization of a hash.
//
function hash_initialize() = [];

// hash_add:
//
// Adds <key>:<value> to <hash>. This does not check for duplicates. Use hash_set to remove duplicates.
//
function hash_add( hash, key, value ) = assert( is_list(hash) ) concat( hash, [[key, value]] );

// hash_size:
//
// Returns the size of <hash>.
//
function hash_size( hash ) = assert( is_list(hash) ) len(hash);

// hash_is_empty:
//
// Returns true if <hash> is empty.
//
function hash_is_empty( hash ) = assert( is_list(hash) ) len(hash) == 0;

// hash_keys:
//
// Return the keys of <hash> in an array.
//
function hash_keys( hash ) = assert( is_list(hash) ) [ for( i = hash ) i[0] ]; 

// hash_values:
//
// Return the values of <hash> in an array.
//
function hash_values( hash ) = assert( is_list(hash) ) [ for( i = hash ) i[1] ]; 

// hash_get:
//
// Returns the value associated with key <key> from <hash> or undef if it does not exist.
//
function hash_get( hash, key ) = assert( is_list(hash) ) [ for( i = hash ) if( key == i[0] ) i[1] ][0];

// hash_exists:
//
// Returns true if the key <key> exists in <hash>.
//
function hash_exists( hash, key ) = assert( is_list(hash) ) len( [ for( i = hash ) if( key == i[0] ) true ] ) != 0;

// hash_get_default:
//
// Returns the value associated with key <key> from <hash> or <default_value> if it does not exist.
//
function hash_get_default( hash, key, default_value ) = hash_exists( hash, key ) ? hash_get( hash, key ) : default_value; 

// hash_get_default_hash:
//
// Returns the value associated with key <key> from <hash>, falling back to <default_hash> if it does not exist.
//
function hash_get_default_hash( hash, key, default_hash ) = hash_exists( hash, key ) ? hash_get( hash, key ) : hash_get( default_hash, key ); 

// hash_delete:
//
// Deletes key <key> from <hash> if it exists and returns the new hash.
//
function hash_delete( hash, key ) = assert( is_list(hash) ) [ for( i = hash ) if( key != i[0] ) i ];

// hash_set:
//
// Set key <key> to associated <value> in <hash>, deleting it if it already exists,  and returns the new hash.
//
function hash_set( hash, key, value ) = hash_exists( hash, key ) ? hash_add( hash_delete( hash, key ), key, value ) : hash_add( hash, key, value );
