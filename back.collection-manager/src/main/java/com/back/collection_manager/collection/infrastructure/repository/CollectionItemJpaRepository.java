package com.back.collection_manager.collection.infrastructure.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.back.collection_manager.collection.infrastructure.entity.CollectionItemEntity;

public interface CollectionItemJpaRepository extends JpaRepository<CollectionItemEntity,UUID> {}
