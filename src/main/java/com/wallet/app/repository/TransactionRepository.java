package com.wallet.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.wallet.app.model.Transaction;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, String>
{

    
}
