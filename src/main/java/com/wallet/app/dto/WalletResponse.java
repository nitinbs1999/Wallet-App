package com.wallet.app.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WalletResponse {

    private String walletId;
    private String ownerName;
    private int balance;
    private Status status;
}
