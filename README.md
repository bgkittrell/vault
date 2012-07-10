# Vault - Node.js Media File Server
## Secure. Fast. Scalable. Simple.

Vault's main purpose is to make it easy to setup your own media file server now, with the intention that it will grow to a massive scale. It's very much inspired 
by Facebook's [Haystack](http://static.usenix.org/event/osdi10/tech/full_papers/Beaver.pdf), though it is not a direct implementation.  

### Features
- REST API
- On-the-fly Image resizing
- Video/Audio transcoding (Through 3rd Parties like [Zencoder](http://zencoder.com))
- Server replication
- Can run on comodity hardware
- Infinitely scalable
- True file security through API callbacks (Not just obscurity)

Vault isn't for everyone. If you're just looking for cloud media hosting, I recommend [Transloadit](https://transloadit.com/).  Though I haven't used the service, it has very similar features to Vault.

### Architecture

A Vault system can start with just one server by itself.  Your application will upload files directly to the Vault from the browser and the vault will return a UUID for the file.  That UUID will be stored in your application's database.  When you need to access that file, the Vault client will generate a URL using the UUID.   

When you're ready to add redundancy you just create a new Vault server and point it to the first one.  The first server will act as a Registry and keep track of all of the Vaults.  The client running on your application will randomly choose a Vault server from the Registry when generating urls, balancing the load.  Files uploaded to any Vault will automatically be replicated to the other Vaults. 

A collection of Vaults is called a Bank. The system is designed so that a Vault can run on a physical server with a set amount of storage.  It doesn't matter how much, but each Vault within Bank should have the same amount relative to each other.  Once a Bank is full, a new Bank of Vaults needs to be created and the old Bank will be marked as read-only.  The client will no longer write new files to the old Bank, but will still serve files as usual.  At this point your application will need to track what Bank a file resides on, in addition to the file UUID.  

That's the quick overview, more details to come. 

### Status

Vault will soon be used in production for [LiveOn](http://www.liveon.com) and [Doodlekit](http://doodlekit.com) shortly thereafter.  All of the features and architecture have been proven out in a staging environment.  

## Installation

### Prerequisites
- Node (http://nodejs.org/)
- CoffeeScript (http://coffeescript.org/)
- GraphicsMagick (http://www.graphicsmagick.org/)

### Checkout (You should fork so you can customize the configuration)
``` bash
  $ git clone git://github.com/liveondev/vault.git
```

### Install Node Dependencies
``` bash
  $ npm install
```

### Starting Server
``` bash
$ coffee server --wide-open
```
Wide open disables all security for quick testing.

### Running Tests
``` bash
$ coffee test/all.coffee
```

## Usage

### Uploading
``` bash
$ curl --form image1=@./test/data/han.jpg http://localhost:7000
```

### Downloading
Grab the UUID from the upload response 

Example URL:

http://localhost:7000/63543bfb-349a-4c93-90ed-6023c91c5c09 

If it's an image:
 
http://localhost:7000/thumb/63543bfb-349a-4c93-90ed-6023c91c5c09 
http://localhost:7000/medium/63543bfb-349a-4c93-90ed-6023c91c5c09 
http://localhost:7000/large/63543bfb-349a-4c93-90ed-6023c91c5c09 

### More Examples

For more usage examples look at the tests under test/functional

## Roadmap

We're just getting started with Vault.  Here are some features to expect in the future.

- CDN support for high traffic files
- Vault clients for various languages and frameworks
- Haystack style block stores (Possibly)
- Performance optimization
- More documentation


