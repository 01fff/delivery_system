const { MongoClient } = require('mongodb');
require('dotenv').config();

async function testMongoDB() {
  console.log('========================================');
  console.log('Testando conexão com MongoDB...');
  console.log('========================================\n');

  const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
  console.log(`URI: ${uri}`);
  console.log(`Database: ${process.env.MONGO_DB_NAME || 'delivery_system'}\n`);

  const client = new MongoClient(uri);

  try {
    console.log('Conectando...');
    await client.connect();
    console.log('✓ Conectado ao MongoDB com sucesso!\n');

    const db = client.db(process.env.MONGO_DB_NAME || 'delivery_system');

    // Testa ping
    console.log('Testando ping...');
    await db.admin().ping();
    console.log('✓ Ping bem-sucedido!\n');

    // Lista collections
    console.log('Listando collections...');
    const collections = await db.listCollections().toArray();
    console.log(`Encontradas ${collections.length} collections:`);
    collections.forEach(col => console.log(`  - ${col.name}`));

    if (collections.length === 0) {
      console.log('  (nenhuma collection ainda - será criada automaticamente ao inserir dados)');
    }

    console.log('\n========================================');
    console.log('✓ MongoDB está funcionando corretamente!');
    console.log('========================================\n');

  } catch (error) {
    console.error('\n========================================');
    console.error('✗ ERRO ao conectar ao MongoDB:');
    console.error('========================================');
    console.error(error.message);
    console.error('\nVerifique:');
    console.error('1. MongoDB está instalado e rodando?');
    console.error('   - Windows: verifique se o serviço MongoDB está ativo');
    console.error('   - No terminal: mongosh (para testar)');
    console.error('2. A URI no .env está correta?');
    console.error('   - MONGO_URI=mongodb://localhost:27017');
    console.error('3. Firewall não está bloqueando a porta 27017?');
    console.error('========================================\n');
    process.exit(1);
  } finally {
    await client.close();
    console.log('Conexão encerrada.\n');
  }
}

testMongoDB();