package com.wallet.app.dto;

import com.wallet.app.model.TransactionType;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TransactionRequest 
{
    private TransactionType type;
    private int amount;
}
