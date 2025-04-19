from fastapi import FastAPI, Depends, HTTPException
from permit import Permit
from permit.sync import wait_for_permit_sync
import os

app = FastAPI()
permit = Permit(
    token=os.getenv("PERMIT_API_KEY"),
    pdp="cloud",
)

# Wait for permit to sync
wait_for_permit_sync(permit)

def get_current_user():
    # In a real app, this would come from your auth system
    return {
        "id": "user123",
        "first_name": "John",
        "last_name": "Doe",
        "email": "john@example.com",
        "roles": ["customer"]
    }

@app.get("/accounts/{account_id}")
async def get_account(account_id: str, user=Depends(get_current_user)):
    # Check if user has permission to access this account
    permitted = permit.check(
        user["id"],
        "read",
        f"account:{account_id}",
        {
            "tenant": "default",
            "resource": {
                "owner_id": account_id,
                "type": "account"
            }
        }
    )
    
    if not permitted:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # If permitted, return account details
    return {
        "id": account_id,
        "balance": 1000,
        "status": "active"
    }

@app.post("/accounts/{account_id}/transfer")
async def transfer_money(
    account_id: str,
    amount: float,
    user=Depends(get_current_user)
):
    # Check if user has permission to transfer money
    permitted = permit.check(
        user["id"],
        "transfer",
        f"account:{account_id}",
        {
            "tenant": "default",
            "resource": {
                "owner_id": account_id,
                "type": "account",
                "amount": amount
            }
        }
    )
    
    if not permitted:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # If permitted, process transfer
    return {"status": "success", "transferred": amount}
