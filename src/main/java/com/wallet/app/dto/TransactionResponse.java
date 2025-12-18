package com.wallet.app.dto;

import com.wallet.app.model.TransactionType;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class TransactionResponse {
    
 private String transactionId;
 private String walletId;
 private TransactionType type;
 private int amount;
 private int balanceAfter;

}
