class NullChannel {

  connect() { return this; }
  disconnect() { return this; }
  fromSource() { return this; }
  fromSourceNode() { return this; }
  toTarget() { return this; }
  toTargetNode() { return this; }
  withTransform() { return this; }
}


const nullChannel = new NullChannel();

export default function getNullChannel() {
  return nullChannel;
}
