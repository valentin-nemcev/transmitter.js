class NullChannel {

  connect() { return this; }
  disconnect() { return this; }
  fromSource() { return this; }
  toTarget() { return this; }
  withTransform() { return this; }
}


const nullChannel = new NullChannel();

export default function getNullChannel() {
  return nullChannel;
}
