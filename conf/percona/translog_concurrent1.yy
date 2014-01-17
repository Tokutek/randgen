# Copyright (C) 2010 Patrick Crews. All rights reserved.
# Use is subject to license terms.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
# USA

# This grammar is designed to generate a transactional workload for validating transaction handling and replication
# setups
#
# This is still a work in progress and is likely to change.
# We are generating a fair number of invalid queries and we could tighten things up, however,
# we have found a number of bugs with this grammar as it currently exists.

query:
	transaction | transaction | 
        normal_query | normal_query | normal_query ;

normal_query:
	select | select |
	select | select |
        select | select |
	select | select |
        insert_query | update | delete |
	insert_query | update | delete |
	insert_query | update | delete |
	insert_query | update | delete |
	insert_query | update | delete | 
        insert_query | update | delete |
	insert_query | update | delete |
	insert_query | update | delete |
	insert_query | update | delete |
	insert_query | update | delete |
        SAVEPOINT A /*Generated by THREAD_ID _thread_id*/ ; 
        #ROLLBACK TO SAVEPOINT A /*Generated by THREAD_ID _thread_id*/ ;

normal_query_list:
  normal_query_list ; normal_query ; normal_query ; normal_query ; normal_query ; normal_query | 
  normal_query ; normal_query ; normal_query ; normal_query ; normal_query ; normal_query |
  normal_query ; normal_query ; normal_query ; normal_query ;

transaction:
  SET AUTOCOMMIT=OFF /*Generated by THREAD_ID _thread_id*/ ; START TRANSACTION /*Generated by THREAD_ID _thread_id*/ ; normal_query_list ; end_transaction ; SET AUTOCOMMIT=ON /*Generated by THREAD_ID _thread_id*/ ;

end_transaction:
  commit_rollback ; 

commit_rollback:
  COMMIT /*Generated by THREAD_ID _thread_id*/| 
  COMMIT /*Generated by THREAD_ID _thread_id*/| 
  COMMIT /*Generated by THREAD_ID _thread_id*/| 
  COMMIT /*Generated by THREAD_ID _thread_id*/| 
  COMMIT /*Generated by THREAD_ID _thread_id*/| 
  ROLLBACK /*Generated by THREAD_ID _thread_id*/;


select:
	SELECT select_list FROM join_list where LIMIT large_digit for_update_lock_in_share_mode /*Generated by THREAD_ID _thread_id*/ ;

select_list:
	X . _field_key | X . _field_key |
	X . `pk` |
	X . _field |
	* |
	( subselect );

subselect:
	SELECT _field_key FROM _table WHERE `pk` = value ;

# Use index for all joins
join_list:
	_table AS X | 
	_table AS X LEFT JOIN _table AS Y USING ( _field_key );

for_update_lock_in_share_mode:
	| | | | | 
	FOR UPDATE |
	LOCK IN SHARE MODE ;

ignore:
	| 
	IGNORE ;

low_priority:
	| | | LOW_PRIORITY;

insert_query:
  insert_replace INTO _table ( insert_column_list ) 
  SELECT insert_column_list 
  FROM _table where_insert 
  ORDER BY _field_list LIMIT insert_limit /*Generated by THREAD_ID _thread_id*/;

insert_replace:
  INSERT | INSERT | INSERT | INSERT | INSERT |
  INSERT | INSERT | INSERT | INSERT | INSERT |
  REPLACE ;

insert_column_list:
# We use a set column list because even though all tables have the same
# columns, each table has a different order of those columns for 
# enhanced randomness
 `col_char_10` , `col_char_10_key` , `col_char_10_not_null` , `col_char_10_not_null_key` ,
 `col_char_255` , `col_char_255_key` , `col_char_255_not_null` , `col_char_255_not_null_key` ,
 `col_int` , `col_int_key` , `col_int_not_null` , `col_int_not_null_key` ,
 `col_bigint` , `col_bigint_key` , `col_bigint_not_null` , `col_bigint_not_null_key` ,
 `col_enum` , `col_enum_key` , `col_enum_not_null` , `col_enum_not_null_key` 
 ;

update:
	UPDATE _table SET update_clause where_insert ORDER BY _field_list LIMIT large_digit /*Generated by THREAD_ID _thread_id*/ ;

update_clause:
  no_pk_int_field_name = int_value ;

# We use a smaller limit on DELETE so that we delete less than we insert

delete:
	DELETE FROM _table where_insert ORDER BY _field_list LIMIT small_digit /*Generated by THREAD_ID _thread_id*/ ;

quick:
	| 
	QUICK ;

order_by:
	| ORDER BY X . _field_key ;

# Use an index at all times
where:
	|
	WHERE X . _field_key < value | 	# Use only < to reduce deadlocks
	WHERE X . _field_key IN ( value , value , value , value , value ) |
	WHERE X . int_field_name BETWEEN small_digit AND large_digit |
	WHERE X . int_field_name BETWEEN _tinyint_unsigned AND _int_unsigned ;

where_disabled: 
# only used in select's, but causing crashes on bad
# compares like enum to int
	WHERE X . _field_key = ( subselect ) ;
       

where_delete:
	| ;
	

where_insert:
    |
    WHERE int_field_name compare_operator int_value |
    WHERE char_field_name compare_operator char_value |
    WHERE int_field_name IN (int_value_list) |
    WHERE char_field_name IN (char_value_list) |
    WHERE int_field_name BETWEEN int_value AND int_value |
    WHERE int_field BETWEEN _tinyint_unsigned AND _int_unsigned |
    WHERE int_field BETWEEN small_digit AND large_digit |
    where_fuzz ;

where_fuzz:
# rules to introduce some fuzz testing 
# we deliberately allow the chance of bad
# comparisons here to see what happens
    WHERE _field_key = ( subselect ) |
    WHERE _field_key compare_operator value |
    WHERE _field_key IN ( subselect ) ;

compare_operator:
  = | = | = | = | < | > | <= | >= | != ;



int_value:
  _digit | _digit | large_digit | small_digit | 
  _digit | insert_limit | _tinyint_unsigned |
  _digit | _digit | large_digit | small_digit | 
  _digit | insert_limit | _tinyint_unsigned |
  value ;

int_value_list:  
  int_value_list, int_value | int_value | int_value ;

char_value:
  _char | _char | _quid ;

char_value_list:
  char_value_list, char_value | char_value | char_value ;

int_field_name:
    `pk` | `col_int_key` | `col_int` |
    `col_bigint` | `col_bigint_key` |
    `col_int_not_null` | `col_int_not_null_key` ;

no_pk_int_field_name:
    `col_int_key` | `col_int` |
    `col_bigint` | `col_bigint_key` |
    `col_int_not_null` | `col_int_not_null_key` ;    


char_field_name:
      `col_char_10` | `col_char_10_key` | 
      `col_char_10_not_null_key` | `col_char_10_not_null` |
      `col_char_255` | `col_char_255_key` |
      `col_char_255_not_null` | `col_char_255_not_null_key` ;

large_digit:
	5 | 6 | 7 | 8 ;

small_digit:
	1 | 2 | 3 | 4 ;

insert_limit:
   10 | 10 | 25 | 25 | 25 | 25 | 50 | 50 | 100 ;

value:
	_digit | _tinyint_unsigned | _varchar(1) | _int_unsigned ;

zero_one:
	0 | 0 | 1;
