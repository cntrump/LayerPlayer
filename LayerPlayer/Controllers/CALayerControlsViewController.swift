/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class CALayerControlsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

  @IBOutlet weak var contentsGravityPickerValueLabel: UILabel!
  @IBOutlet weak var contentsGravityPicker: UIPickerView!
  @IBOutlet var switches: [UISwitch]!
  @IBOutlet var sliderValueLabels: [UILabel]!
  @IBOutlet var sliders: [UISlider]!
  @IBOutlet weak var borderColorSlidersValueLabel: UILabel!
  @IBOutlet var borderColorSliders: [UISlider]!
  @IBOutlet weak var backgroundColorSlidersValueLabel: UILabel!
  @IBOutlet var backgroundColorSliders: [UISlider]!
  @IBOutlet weak var shadowOffsetSlidersValueLabel: UILabel!
  @IBOutlet var shadowOffsetSliders: [UISlider]!
  @IBOutlet weak var shadowColorSlidersValueLabel: UILabel!
  @IBOutlet var shadowColorSliders: [UISlider]!
  @IBOutlet weak var magnificationFilterSegmentedControl: UISegmentedControl!

  enum Row: Int {
    case contentsGravity, contentsGravityPicker, displayContents, geometryFlipped, hidden, opacity, cornerRadius, borderWidth, borderColor, backgroundColor, shadowOpacity, shadowOffset, shadowRadius, shadowColor, magnificationFilter
  }
  enum Switch: Int {
    case displayContents, geometryFlipped, hidden
  }
  enum Slider: Int {
    case opacity, cornerRadius, borderWidth, shadowOpacity, shadowRadius
  }
  enum ColorSlider: Int {
    case red, green, blue
  }
  enum MagnificationFilter: Int {
    case linear, nearest, trilinear
  }

  weak var layerViewController: CALayerViewController!
  var contentsGravityValues = [convertFromCALayerContentsGravity(.center), convertFromCALayerContentsGravity(.top), convertFromCALayerContentsGravity(.bottom), convertFromCALayerContentsGravity(.left), convertFromCALayerContentsGravity(.right), convertFromCALayerContentsGravity(.topLeft), convertFromCALayerContentsGravity(.topRight), convertFromCALayerContentsGravity(.bottomLeft), convertFromCALayerContentsGravity(.bottomRight), convertFromCALayerContentsGravity(.resize), convertFromCALayerContentsGravity(.resizeAspect), convertFromCALayerContentsGravity(.resizeAspectFill)] as NSArray
  var contentsGravityPickerVisible = false

  // MARK: - View life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    updateSliderValueLabels()
  }

  // MARK: - IBActions

  @IBAction func switchChanged(_ sender: UISwitch) {
    let switchesArray = switches as NSArray
    let theSwitch = Switch(rawValue: switchesArray.index(of: sender))!

    switch theSwitch {
    case .displayContents:
      layerViewController.layer.contents = sender.isOn ? layerViewController.star : nil
    case .geometryFlipped:
      layerViewController.layer.isGeometryFlipped = sender.isOn
    case .hidden:
      layerViewController.layer.isHidden = sender.isOn
    }
  }

  @IBAction func sliderChanged(_ sender: UISlider) {
    let slidersArray = sliders as NSArray
    let slider = Slider(rawValue: slidersArray.index(of: sender))!

    switch slider {
    case .opacity:
      layerViewController.layer.opacity = sender.value
    case .cornerRadius:
      layerViewController.layer.cornerRadius = CGFloat(sender.value)
    case .borderWidth:
      layerViewController.layer.borderWidth = CGFloat(sender.value)
    case .shadowOpacity:
      layerViewController.layer.shadowOpacity = sender.value
    case .shadowRadius:
      layerViewController.layer.shadowRadius = CGFloat(sender.value)
    }

    updateSliderValueLabel(slider)
  }

  @IBAction func borderColorSliderChanged(_ sender: UISlider) {
    let colorAndLabel = colorAndLabelForSliders(borderColorSliders)
    layerViewController.layer.borderColor = colorAndLabel.color
    borderColorSlidersValueLabel.text = colorAndLabel.label
  }

  @IBAction func backgroundColorSliderChanged(_ sender: UISlider) {
    let colorAndLabel = colorAndLabelForSliders(backgroundColorSliders)
    layerViewController.layer.backgroundColor = colorAndLabel.color
    backgroundColorSlidersValueLabel.text = colorAndLabel.label
  }

  @IBAction func shadowOffsetSliderChanged(_ sender: UISlider) {
    let width = CGFloat(shadowOffsetSliders[0].value)
    let height = CGFloat(shadowOffsetSliders[1].value)
    layerViewController.layer.shadowOffset = CGSize(width: width, height: height)
    shadowOffsetSlidersValueLabel.text = "Width: \(Int(width)), Height: \(Int(height))"
  }

  @IBAction func shadowColorSliderChanged(_ sender: UISlider) {
    let colorAndLabel = colorAndLabelForSliders(shadowColorSliders)
    layerViewController.layer.shadowColor = colorAndLabel.color
    shadowColorSlidersValueLabel.text = colorAndLabel.label
  }

  @IBAction func magnificationFilterSegmentedControlChanged(_ sender: UISegmentedControl) {
    let filter = MagnificationFilter(rawValue: sender.selectedSegmentIndex)!
    var filterValue = ""

    switch filter {
    case .linear:
      filterValue = convertFromCALayerContentsFilter(.linear)
    case .nearest:
      filterValue = convertFromCALayerContentsFilter(.nearest)
    case .trilinear:
      filterValue = convertFromCALayerContentsFilter(.trilinear)
    }

    layerViewController.layer.magnificationFilter = convertToCALayerContentsFilter(filterValue)
  }

  // MARK: - Triggered actions

  func showContentsGravityPicker() {
    contentsGravityPickerVisible = true
    relayoutTableViewCells()
    let index = contentsGravityValues.index(of: convertFromCALayerContentsGravity(layerViewController.layer.contentsGravity))
    contentsGravityPicker.selectRow(index, inComponent: 0, animated: false)
    contentsGravityPicker.isHidden = false
    contentsGravityPicker.alpha = 0.0

    UIView.animate(withDuration: 0.25, animations: {
      [unowned self] in
      self.contentsGravityPicker.alpha = 1.0
    })
  }

  func hideContentsGravityPicker() {
    if contentsGravityPickerVisible {
      tableView.isUserInteractionEnabled = false
      contentsGravityPickerVisible = false
      relayoutTableViewCells()

      UIView.animate(withDuration: 0.25, animations: {
        [unowned self] in
        self.contentsGravityPicker.alpha = 0.0
        }, completion: {
          [unowned self] _ in
          self.contentsGravityPicker.isHidden = true
          self.tableView.isUserInteractionEnabled = true
      })
    }
  }

  // MARK: - Helpers

  func updateContentsGravityPickerValueLabel() {
    contentsGravityPickerValueLabel.text = convertFromCALayerContentsGravity(layerViewController.layer.contentsGravity)
  }

  func updateSliderValueLabels() {
    for slider in Slider.opacity.rawValue...Slider.shadowRadius.rawValue {
      updateSliderValueLabel(Slider(rawValue: slider)!)
    }
  }

  func updateSliderValueLabel(_ sliderEnum: Slider) {
    let index = sliderEnum.rawValue
    let label = sliderValueLabels[index]
    let slider = sliders[index]

    switch sliderEnum {
    case .opacity, .shadowOpacity:
      label.text = String(format: "%.1f", slider.value)
    case .cornerRadius, .borderWidth, .shadowRadius:
      label.text = "\(Int(slider.value))"
    }
  }

  func colorAndLabelForSliders(_ sliders: [UISlider]) -> (color: CGColor, label: String) {
    let red = CGFloat(sliders[0].value)
    let green = CGFloat(sliders[1].value)
    let blue = CGFloat(sliders[2].value)
    let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0).cgColor
    let label = "RGB: \(Int(red)), \(Int(green)), \(Int(blue))"
    return (color: color, label: label)
  }

  func relayoutTableViewCells() {
    tableView.beginUpdates()
    tableView.endUpdates()
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let row = Row(rawValue: indexPath.row)!

    if row == .contentsGravityPicker {
      return contentsGravityPickerVisible ? 162.0 : 0.0
    } else {
      return 44.0
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = Row(rawValue: indexPath.row)!

    switch row {
    case .contentsGravity where !contentsGravityPickerVisible:
      showContentsGravityPicker()
    default:
      hideContentsGravityPicker()
    }
  }

  // MARK: - UIPickerViewDataSource

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return contentsGravityValues.count
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return contentsGravityValues[row] as? String
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    layerViewController.layer.contentsGravity = convertToCALayerContentsGravity(contentsGravityValues[row] as! String)
    updateContentsGravityPickerValueLabel()
  }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromCALayerContentsGravity(_ input: CALayerContentsGravity) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromCALayerContentsFilter(_ input: CALayerContentsFilter) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToCALayerContentsFilter(_ input: String) -> CALayerContentsFilter {
	return CALayerContentsFilter(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToCALayerContentsGravity(_ input: String) -> CALayerContentsGravity {
	return CALayerContentsGravity(rawValue: input)
}
