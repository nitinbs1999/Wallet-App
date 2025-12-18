package com.wallet.app.dto;

import lombok.Data;

@Data
public class WalletRequest {

    private String walletId;
    private String ownerName;
    private int balance;
    

}
