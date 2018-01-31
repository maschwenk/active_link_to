require_relative 'test_helper'

class ActiveLinkToTest < MiniTest::Test
  def test_is_active_link_symbol_inclusive
    set_path('/root')
    assert active_link?('/root', :inclusive)

    set_path('/root?param=test')
    assert active_link?('/root', :inclusive)

    set_path('/root/child/sub-child')
    assert active_link?('/root', :inclusive)

    set_path('/other')
    refute active_link?('/root', :inclusive)
  end

  def test_is_active_link_symbol_inclusive_implied
    set_path('/root/child/sub-child')
    assert active_link?('/root')
  end

  def test_is_active_link_symbol_inclusive_similar_path
    set_path('/root/abc')
    refute active_link?('/root/a', :inclusive)
  end

  def test_is_active_link_symbol_inclusive_with_last_slash
    set_path('/root/abc')
    assert active_link?('/root/')
  end

  def test_is_active_link_symbol_inclusive_with_last_slash_and_similar_path
    set_path('/root_path')
    refute active_link?('/root/')
  end

  def test_is_active_link_symbol_inclusive_with_link_params
    set_path('/root?param=test')
    assert active_link?('/root?attr=example')
  end

  def test_is_active_link_symbol_exclusive
    set_path('/root')
    assert active_link?('/root', :exclusive)

    set_path('/root?param=test')
    assert active_link?('/root', :exclusive)

    set_path('/root/child')
    refute active_link?('/root', :exclusive)
  end

  def test_is_active_link_symbol_exclusive_with_link_params
    set_path('/root?param=test')
    assert active_link?('/root?attr=example', :exclusive)
  end

  def test_is_active_link_regex
    set_path('/root')
    assert active_link?('/', /^\/root/)

    set_path('/root/child')
    assert active_link?('/', /^\/r/)

    set_path('/other')
    refute active_link?('/', /^\/r/)
  end

  def test_is_active_link_with_anchor
    set_path('/foo')
    assert active_link?('/foo#anchor', :exclusive)
  end

  def test_is_active_link_with_memoization
    set_path('/')
    assert active_link?('/', :exclusive)

    set_path('/other', false)
    assert active_link?('/', :exclusive)
  end

  def test_active_link_to_class
    set_path('/root')
    assert_equal 'active', active_link_to_class('/root')
    assert_equal 'on', active_link_to_class('/root', class_active: 'on')

    assert_equal '', active_link_to_class('/other')
    assert_equal 'off', active_link_to_class('/other', class_inactive: 'off')
  end

  def test_active_link_to
    set_path('/root')
    link = active_link_to('label', '/root')
    assert_html link, 'a.active[href="/root"]', 'label'

    link = active_link_to('label', '/other')
    assert_html link, 'a[href="/other"]', 'label'
  end

  def test_active_link_to_with_existing_class
    set_path('/root')
    link = active_link_to('label', '/root', class: 'current')
    assert_html link, 'a.current.active[href="/root"]', 'label'

    link = active_link_to('label', '/other', class: 'current')
    assert_html link, 'a.current[href="/other"]', 'label'
  end

  def test_active_link_to_with_custom_classes
    set_path('/root')
    link = active_link_to('label', '/root', class_active: 'on')
    assert_html link, 'a.on[href="/root"]', 'label'

    link = active_link_to('label', '/other', class_inactive: 'off')
    assert_html link, 'a.off[href="/other"]', 'label'
  end

  def test_should_not_modify_passed_params
    set_path('/root')
    params = {class: 'testing', active: :inclusive}
    out = active_link_to 'label', '/root', params
    assert_html out, 'a.testing.active[href="/root"]', 'label'
    assert_equal ({class: 'testing', active: :inclusive }), params
  end

  def test_active_link_to_with_aria
    set_path('/root')
    link = active_link_to('label', '/root')
    assert_html link, 'a.active[href="/root"][aria-current="page"]', 'label'
  end

  def test_active_link_to_with_utf8
    set_path('/äöü')
    link = active_link_to('label', '/äöü')
    assert_html link, 'a.active[href="/äöü"]', 'label'
  end
end
