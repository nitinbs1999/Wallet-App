package com.wallet.app.exception;

public class WalletAlreadyExistsException extends RuntimeException {
    
    public WalletAlreadyExistsException(String message) {
        super(message);
    }
}
