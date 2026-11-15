package com.back.collection_manager.collection.infrastructure.entity;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name="collection_item")
@Getter 
@Setter
public class CollectionItemEntity {
 
@Id
 private UUID id;
 private String title;
 private String type;
 private boolean owned;
}
