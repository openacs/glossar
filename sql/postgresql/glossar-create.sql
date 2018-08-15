-- 
-- packages/glossar/sql/postgresql/glossar-create.sql
-- 
-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
-- @creation-date 2005-07-06
-- @cvs-id $Id$
--



-- Create both Tables gl_glossars and gl_glossar_terms



create table gl_glossars (
			glossar_id       integer primary key references acs_objects(object_id),
			owner_id 	 integer not null  references acs_objects(object_id),
			source_category_id integer not null  references categories(category_id), 
			target_category_id integer default null references categories(category_id),
			etat_id		integer default null references acs_objects(object_id)
			);





create table gl_glossar_terms (
			term_id		 integer primary key,
			owner_id         integer references acs_objects,
			source_text 	 varchar(4000) default null,
			target_text      varchar(4000) default null,
			dont_text        varchar(4000) default null
			);	




