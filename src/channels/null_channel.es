class NullChannel {

  connect() { return this; }
  disconnect() { return this; }
}


const nullChannel = new NullChannel();

export default function getNullChannel() {
  return nullChannel;
}
