package com.back.collection_manager.collection.api.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.back.collection_manager.collection.api.dto.request.CreateCollectionItemRequest;
import com.back.collection_manager.collection.application.service.CollectionItemService;
import com.back.collection_manager.collection.infrastructure.entity.CollectionItemEntity;

import io.swagger.v3.oas.annotations.parameters.RequestBody;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/items")
@RequiredArgsConstructor
public class CollectionItemController {
 private final CollectionItemService service;
 @PostMapping
 public CollectionItemEntity create(@RequestBody CreateCollectionItemRequest request){
   return service.create(request.getTitle(),request.getType());
 }
 @GetMapping
 public List<CollectionItemEntity> getAll(){
   return service.findAll();
 }
}
