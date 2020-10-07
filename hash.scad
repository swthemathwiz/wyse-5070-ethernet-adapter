//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    hash.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Implementation of a hash structure.
//

// hash can be initialized like:
//
//   hash_v = hash_add( hash_add( hash_initialize(), "key1", "value1" ), "key2", value2 );
//
// or perhaps more clearly like:
//
//   hash_v = [
//     [ "key1", "value1" ],
//     [ "key2", value2 ],
//   ];
//
// Then values can be retrieved by:
//
//   v = hash_get( hash_v, "key1" );
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
function hash_is_empty( hash ) = len(hash) == 0;

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
function hash_get_internal_( hash, key, _i = 0 ) = (_i >= len(hash)) ? undef : (hash[_i][0] == key) ? hash[_i][1] : hash_get_internal_( hash, key, _i+1 );
function hash_get( hash, key ) = assert( is_list(hash) ) hash_get_internal_( hash, key );

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

// hash_exists:
//
// Returns true if the key <key> exists in <hash>.
//
function hash_exists( hash, key ) = !is_undef( hash_get( hash, key ) );

// hash_delete:
//
// Deletes key <key> from <hash> if it exists and returns the new hash.
//
function hash_delete_internal_( hash, key, _i = 0, _v = [] ) = (_i >= len(hash)) ? _v : hash_delete_internal_( hash, key, _i+1, hash[_i][0] == key ? _v : concat(_v,[hash[_i]]) );
function hash_delete( hash, key ) = assert( is_list(hash) ) hash_delete_internal_( hash, key );

// hash_set:
//
// Set key <key> to associated <value> in <hash>, deleting it if it already exists,  and returns the new hash.
//
function hash_set( hash, key, value ) = hash_exists( hash, key ) ? hash_add( hash_delete( hash, key ), key, value ) : hash_add( hash, key, value );
