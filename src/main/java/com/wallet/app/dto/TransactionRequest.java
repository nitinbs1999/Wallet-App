package com.wallet.app.dto;

import com.wallet.app.model.TransactionType;

import lombok.Data;

@Data
public class TransactionRequest 
{
    private TransactionType type;
    private int amount;
}
