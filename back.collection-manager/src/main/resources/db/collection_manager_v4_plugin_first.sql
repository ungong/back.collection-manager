-- =============================================================
-- COLLECTION MANAGER V4 - PLUGIN FIRST ARCHITECTURE
-- Objetivo:
-- El núcleo NO conoce Comics, Libros o Juegos.
-- Cada módulo se registra como plugin.
-- Los atributos son dinámicos y configurables.
-- Pensado para Spring Boot + PostgreSQL + Liquibase.
-- =============================================================

/*
CORE - IDENTIDAD
*/
CREATE TABLE app_user (
 id UUID PRIMARY KEY,
 username VARCHAR(100) NOT NULL UNIQUE,
 email VARCHAR(255) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 enabled BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL,
 updated_at TIMESTAMP NOT NULL,
 version BIGINT NOT NULL DEFAULT 0
);

/*
CORE - COLECCIONES
Permite varias colecciones por usuario.
*/
CREATE TABLE collection (
 id UUID PRIMARY KEY,
 owner_id UUID NOT NULL,
 name VARCHAR(200) NOT NULL,
 description VARCHAR(1000),
 created_at TIMESTAMP NOT NULL,
 updated_at TIMESTAMP NOT NULL,
 version BIGINT NOT NULL DEFAULT 0,
 FOREIGN KEY(owner_id) REFERENCES app_user(id)
);

/*
REGISTRO DE PLUGINS
comic-plugin, book-plugin, boardgame-plugin...
*/
CREATE TABLE plugin_module (
 id UUID PRIMARY KEY,
 code VARCHAR(100) NOT NULL UNIQUE,
 name VARCHAR(200) NOT NULL,
 version VARCHAR(50) NOT NULL,
 active BOOLEAN NOT NULL DEFAULT TRUE,
 description VARCHAR(1000)
);

/*
TIPOS DE CONTENIDO GESTIONADOS POR UN PLUGIN
COMIC, BOOK, BOARDGAME, MOVIE...
*/
CREATE TABLE entity_type (
 id UUID PRIMARY KEY,
 plugin_id UUID NOT NULL,
 code VARCHAR(100) UNIQUE NOT NULL,
 name VARCHAR(200) NOT NULL,
 FOREIGN KEY(plugin_id) REFERENCES plugin_module(id)
);

/*
ELEMENTO GENERICO DEL SISTEMA
*/
CREATE TABLE collection_item (
 id UUID PRIMARY KEY,
 collection_id UUID NOT NULL,
 entity_type_id UUID NOT NULL,
 owner_id UUID NOT NULL,
 title VARCHAR(500) NOT NULL,
 description CLOB,
 search_text CLOB,
 owned BOOLEAN DEFAULT TRUE NOT NULL,
 deleted BOOLEAN DEFAULT FALSE NOT NULL,
 deleted_at TIMESTAMP,
 created_at TIMESTAMP NOT NULL,
 updated_at TIMESTAMP NOT NULL,
 version BIGINT NOT NULL DEFAULT 0,
 FOREIGN KEY(collection_id) REFERENCES collection(id),
 FOREIGN KEY(entity_type_id) REFERENCES entity_type(id),
 FOREIGN KEY(owner_id) REFERENCES app_user(id)
);

/*
DEFINICION DE ATRIBUTOS DINAMICOS
Ejemplos:
ISBN
Autor
NumeroJugadores
Editorial
*/
CREATE TABLE attribute_definition (
 id UUID PRIMARY KEY,
 entity_type_id UUID NOT NULL,
 code VARCHAR(100) NOT NULL,
 name VARCHAR(200) NOT NULL,
 attribute_type VARCHAR(50) NOT NULL,
 required_flag BOOLEAN DEFAULT FALSE,
 searchable_flag BOOLEAN DEFAULT FALSE,
 sortable_flag BOOLEAN DEFAULT FALSE,
 display_order INTEGER,
 UNIQUE(entity_type_id,code),
 FOREIGN KEY(entity_type_id) REFERENCES entity_type(id)
);

/*
VALORES DE ATRIBUTOS
Modelo EAV.
*/
CREATE TABLE item_attribute_value (
 id UUID PRIMARY KEY,
 item_id UUID NOT NULL,
 attribute_definition_id UUID NOT NULL,
 value_string VARCHAR(4000),
 value_number DECIMAL(30,10),
 value_date DATE,
 value_boolean BOOLEAN,
 FOREIGN KEY(item_id) REFERENCES collection_item(id) ON DELETE CASCADE,
 FOREIGN KEY(attribute_definition_id) REFERENCES attribute_definition(id)
);

/*
ETIQUETAS
*/
CREATE TABLE tag (
 id UUID PRIMARY KEY,
 name VARCHAR(100) UNIQUE NOT NULL,
 color VARCHAR(20)
);

CREATE TABLE item_tag (
 item_id UUID NOT NULL,
 tag_id UUID NOT NULL,
 PRIMARY KEY(item_id,tag_id),
 FOREIGN KEY(item_id) REFERENCES collection_item(id) ON DELETE CASCADE,
 FOREIGN KEY(tag_id) REFERENCES tag(id)
);

/*
UBICACIONES
*/
CREATE TABLE storage_location (
 id UUID PRIMARY KEY,
 parent_id UUID,
 name VARCHAR(200) NOT NULL,
 description VARCHAR(500),
 FOREIGN KEY(parent_id) REFERENCES storage_location(id)
);

CREATE TABLE item_location (
 item_id UUID PRIMARY KEY,
 location_id UUID NOT NULL,
 FOREIGN KEY(item_id) REFERENCES collection_item(id) ON DELETE CASCADE,
 FOREIGN KEY(location_id) REFERENCES storage_location(id)
);

/*
ARCHIVOS
*/
CREATE TABLE file_attachment (
 id UUID PRIMARY KEY,
 item_id UUID NOT NULL,
 file_name VARCHAR(500) NOT NULL,
 storage_path VARCHAR(1000) NOT NULL,
 content_type VARCHAR(100),
 file_size BIGINT,
 checksum VARCHAR(128),
 created_at TIMESTAMP NOT NULL,
 FOREIGN KEY(item_id) REFERENCES collection_item(id)
);

/*
TRACKING
*/
CREATE TABLE wishlist (
 id UUID PRIMARY KEY,
 owner_id UUID NOT NULL,
 entity_type_id UUID NOT NULL,
 title VARCHAR(500) NOT NULL,
 priority INTEGER DEFAULT 3,
 target_price DECIMAL(10,2),
 notes VARCHAR(1000),
 FOREIGN KEY(owner_id) REFERENCES app_user(id),
 FOREIGN KEY(entity_type_id) REFERENCES entity_type(id)
);

CREATE TABLE review (
 id UUID PRIMARY KEY,
 item_id UUID NOT NULL,
 rating DECIMAL(3,2) NOT NULL,
 review_text CLOB,
 review_date DATE,
 CHECK(rating>=0 AND rating<=10),
 FOREIGN KEY(item_id) REFERENCES collection_item(id)
);

CREATE TABLE activity_type (
 id UUID PRIMARY KEY,
 code VARCHAR(50) UNIQUE NOT NULL,
 description VARCHAR(200)
);

CREATE TABLE activity_log (
 id UUID PRIMARY KEY,
 item_id UUID NOT NULL,
 activity_type_id UUID NOT NULL,
 activity_date DATE NOT NULL,
 notes VARCHAR(1000),
 FOREIGN KEY(item_id) REFERENCES collection_item(id),
 FOREIGN KEY(activity_type_id) REFERENCES activity_type(id)
);

/* RELACIONES ENTRE ELEMENTOS */
CREATE TABLE relation_type (
 id UUID PRIMARY KEY,
 code VARCHAR(50) UNIQUE NOT NULL,
 description VARCHAR(200)
);

CREATE TABLE item_relation (
 id UUID PRIMARY KEY,
 parent_item_id UUID NOT NULL,
 child_item_id UUID NOT NULL,
 relation_type_id UUID NOT NULL,
 FOREIGN KEY(parent_item_id) REFERENCES collection_item(id),
 FOREIGN KEY(child_item_id) REFERENCES collection_item(id),
 FOREIGN KEY(relation_type_id) REFERENCES relation_type(id)
);

/* INDICES */
CREATE INDEX idx_item_title ON collection_item(title);
CREATE INDEX idx_item_type ON collection_item(entity_type_id);
CREATE INDEX idx_item_owner ON collection_item(owner_id);
CREATE INDEX idx_item_deleted ON collection_item(deleted);
CREATE INDEX idx_attr_entity_type ON attribute_definition(entity_type_id);
CREATE INDEX idx_attr_value_item ON item_attribute_value(item_id);
CREATE INDEX idx_attr_value_def ON item_attribute_value(attribute_definition_id);
CREATE INDEX idx_review_item ON review(item_id);
CREATE INDEX idx_activity_item ON activity_log(item_id);
CREATE INDEX idx_relation_parent ON item_relation(parent_item_id);
CREATE INDEX idx_relation_child ON item_relation(child_item_id);

/*
EJEMPLO PLUGIN COMIC
INSERT plugin_module (... comic-plugin ...)
INSERT entity_type (... COMIC ...)
INSERT attribute_definition (... serie ...)
INSERT attribute_definition (... numero ...)
INSERT attribute_definition (... dibujante ...)

No requiere crear tablas nuevas.
*/
