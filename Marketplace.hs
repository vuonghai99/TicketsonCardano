{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Marketplace where

import           PlutusTx.Prelude
import           Plutus.V1.Ledger.Api
import           Plutus.V1.Ledger.Contexts
import           PlutusTx
import           Prelude                  (String, Show, IO)

-- Define the data types for the contract
data Sale = Sale
    { seller     :: PubKeyHash  -- Seller's public key hash
    , price      :: Integer     -- Price in Lovelace
    } deriving Show

PlutusTx.makeLift ''Sale

-- Validator logic
{-# INLINABLE marketplaceValidator #-}
marketplaceValidator :: Sale -> () -> ScriptContext -> Bool
marketplaceValidator sale _ ctx = 
    traceIfFalse "Not enough payment sent" correctPayment &&
    traceIfFalse "Wrong signer" signedByBuyer
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    -- Check if the correct amount of payment has been sent
    correctPayment :: Bool
    correctPayment =
        case flattenValue (txOutValue ownOutput) of
            [(cs, tn, amt)] -> amt >= price sale
            _               -> False

    -- Check if the transaction is signed by the buyer
    signedByBuyer :: Bool
    signedByBuyer = txSignedBy info (seller sale)

    -- Reference to the output owned by this script
    ownOutput :: TxOut
    ownOutput =
        case findOwnInput ctx of
            Just i  -> txInInfoResolved i
            Nothing -> traceError "Input not found"

-- Compile the validator to Plutus Core
validator :: Sale -> Validator
validator sale = mkValidatorScript $$(PlutusTx.compile [|| (\sale' -> marketplaceValidator sale') ||])

-- Hash of the validator
validatorHash :: Sale -> ValidatorHash
validatorHash sale = validatorHash validator sale
