package com.wallet.app.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Builder;
import lombok.Data;

@Entity
@Table(name="transactions")
@Data
@Builder
public class Transaction {
 //indexing
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;
 //uniq transaction id
 @Column(nullable=false, unique = true)
 private String transaction_id;

 //we are taking wallet id as foreign key for this table
 @ManyToOne(fetch= FetchType.LAZY)
 @JoinColumn(name="wallet_id",nullable = false)
 private Wallet wallet;
 
@Enumerated(EnumType.STRING)
@Column(nullable = false)
 private TransactionType  type;


 @Column(nullable = false)
 private Integer amount;  

 @Column(nullable=false)
 private Integer balanceAfter;
}
