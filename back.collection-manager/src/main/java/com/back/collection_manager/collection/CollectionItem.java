package com.back.collection_manager.collection;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter 
@Setter 
@NoArgsConstructor 
@AllArgsConstructor 
@Builder
public class CollectionItem {
  private UUID id;
  private String title;
  private String type;
  private boolean owned;
}
