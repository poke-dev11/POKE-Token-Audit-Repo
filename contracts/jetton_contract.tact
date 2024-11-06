import "@stdlib/deploy";
import "./jetton.tact";

message(0xfc708bd2) Mint {
    amount: Int;
    receiver: Address;
}

contract JettonContract with Deployable,Jetton {
    total_supply: Int as coins; // Tracks total supply of Jettons
    owner: Address;             // Address of the contract owner
    content: Cell;              // Metadata/content associated with the Jetton
    mintable: Bool;             // Flag to indicate if minting is allowed

    max_supply: Int as coins;   // Maximum supply of Jettons (not part of Jetton Standards)

    // @owner The address of the Jetton contract owner
    // @content The initial metadata content of the Jetton
    // @max_supply The maximum supply of Jettons that can be minted                     
    init(owner: Address, content: Cell, max_supply: Int) {
        self.total_supply = 0;
        self.owner = owner;
        self.mintable = true;
        self.content = content;
        self.max_supply = max_supply;
    }

    // @msg The Mint message to initiate the minting process
    // @amount Amount of Jettons to mint
    // @receiver Address to receive the minted Jettons
    receive(msg: Mint) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner");
        require(self.mintable, "Not mintable");
        require(self.total_supply + msg.amount <= self.max_supply, "Max supply exceeded");
        self.mint(msg.receiver, msg.amount, self.owner); // (to, amount, response_destination)
    }

    // Close minting permanently
    // Only the owner can call this method to disable further minting
    receive("Owner: MintClose") {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner");
        self.mintable = false;
    }
}
