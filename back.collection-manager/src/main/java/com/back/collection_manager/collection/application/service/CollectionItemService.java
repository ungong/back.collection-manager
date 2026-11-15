package com.back.collection_manager.collection.application.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.back.collection_manager.collection.infrastructure.entity.CollectionItemEntity;
import com.back.collection_manager.collection.infrastructure.repository.CollectionItemJpaRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CollectionItemService {
 private final CollectionItemJpaRepository repository;
 public CollectionItemEntity create(String title,String type){
   CollectionItemEntity e=new CollectionItemEntity();
   e.setId(UUID.randomUUID());
   e.setTitle(title);
   e.setType(type);
   e.setOwned(true);
   return repository.save(e);
 }
 public List<CollectionItemEntity> findAll(){
   return repository.findAll();
 }
}