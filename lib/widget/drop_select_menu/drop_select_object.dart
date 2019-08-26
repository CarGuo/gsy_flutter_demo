class DropSelectObject {
  String title;
  List<DropSelectObject> children;
  bool selected;
  bool selectedCleanOther;

  DropSelectObject(
      {this.title,
      this.children,
      this.selected = false,
      this.selectedCleanOther = false});
}
