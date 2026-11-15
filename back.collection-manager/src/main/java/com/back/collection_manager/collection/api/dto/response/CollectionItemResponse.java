package com.back.collection_manager.collection.api.dto.response;

import java.util.UUID;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class CollectionItemResponse {
 private UUID id;
 private String title;
 private String type;
 private boolean owned;
}